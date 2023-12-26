## Create the backend application

I am using the following structure for the application:

```bash
backend
|-- main.py
|-- config.py
|-- router.py
```

Create a basic application:

```python
# main.py
from app.router import router
from fastapi import FastAPI
app = FastAPI()
app.include_router(router)

# router.py
from fastapi import APIRouter
router = APIRouter()
@router.get("/")
def hello():
    """Hello world route to make sure the app is working correctly"""
    return {"msg": "Hello World!"}
```

Run the app by going to `backend` folder and launch: `uvicorn app.main:app --reload` then go to localhost, port 8000

## Init firebase

- Go to firebase console, `Project Settings` then `Service accounts` and click `Generate new private key`.
- Save the resulting file in your `backend` folder, as `service-account.json`. IMPORTANT: Do not save it to source control, it is sensitive information. I suggest adding `service-account.json` to your `.gitignore`
- Still in the backend folder, create a `.env` file

```bash
# env
ENV=dev
GOOGLE_APPLICATION_CREDENTIALS="./service-account.json"
FRONTEND_URL="http://localhost:4200"
```

Note: In your fastapi app, it is important that the `GOOGLE_APPLICATION_CREDENTIALS` variable is
set and points to the `service-account.json` file. This variable is used when initializing firebase.
In your production environment, if you deploy to google services such as Cloud Run, you don't need to
provide the credentials as they are automatically set for you.

Modify the main.py file. Now firebase is correctly initialised.

```python
# main.py
from app.router import router
from fastapi import FastAPI

import firebase_admin
from dotenv import load_dotenv
import pathlib

# we need to load the env file because it contains the GOOGLE_APPLICATION_CREDENTIALS
basedir = pathlib.Path(__file__).parents[1]
load_dotenv(basedir / ".env")

app = FastAPI()
app.include_router(router)

firebase_admin.initialize_app()
```

Note: you can temporarily add this line to check that your firebase app is correctly loaded:
`print("Current App Name:", firebase_admin.get_app().project_id)`.
If you remove the `load_dotenv`, you should see that the project_id is None.

## Adding CORS

Depending on how you deploy your frontend and your backend, you may encounter CORS issues.
It is actually easy to deal with it in fastapi.
In main.py:

```python
from fastapi.middleware.cors import CORSMiddleware
import os

...
origins = [os.getenv("FRONTEND_URL", "")]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Refactoring

`main.py` is getting a bit complex. Let's refactor by moving logic to `config.py`

```python
## config.py
import os
import pathlib
from functools import lru_cache
from dotenv import load_dotenv
from pydantic_settings import BaseSettings


# we need to load the env file because it contains the GOOGLE_APPLICATION_CREDENTIALS
basedir = pathlib.Path(__file__).parents[1]
load_dotenv(basedir / ".env")

class Settings(BaseSettings):
    """Main settings"""
    app_name: str = "demofirebase"
    env: str = os.getenv("ENV", "development")

    # Needed for CORS
    frontend_url: str = os.getenv("FRONTEND_URL", "NA")


@lru_cache
def get_settings() -> Settings:
    """Retrieves the fastapi settings"""
    return Settings()
```

and now in `main.py`, we can remove all the environment variable logic:

```python
...
# importing config will also call load_dotenv to get GOOGLE_APPLICATION_CREDENTIALS
from app.config import get_settings
...
origins = [settings.frontend_url]
```

## Adding firebase authentication

In the config, we will add the possibility to handle requests from firebase authenticated
users. When a user is authenticated, he will send a bearer token in the authorization header.
In the backend, we must retrieve this user and check that it corresponds to a firebase authenticated user.

To do so we update config.py:

```python

# config.py
...
from typing import Annotated
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin.auth import verify_id_token
...

# use of a simple bearer scheme as auth is handled by firebase and not fastapi
# we set auto_error to False because fastapi incorrectly returns a 403 intead of a 401
# see: https://github.com/tiangolo/fastapi/pull/2120
bearer_scheme = HTTPBearer(auto_error=False)

...

def get_firebase_user_from_token(
    token: Annotated[HTTPAuthorizationCredentials | None], Depends(bearer_scheme)],
) -> dict | None:
    """Uses bearer token to identify firebase user id

    Args:
        token : the bearer token. Can be None as we set auto_error to False

    Returns:
        dict: the firebase user on success
    Raises:
        HTTPException 401 if user does not exist or token is invalid
    """
    try:
        if not token:
            # raise and catch to return 401, only needed because fastapi returns 403
            # by default instead of 401 so we set auto_error to False
            raise ValueError("No token")
        user = verify_id_token(token.credentials)
        return user

    # lots of possible exceptions, see firebase_admin.auth,
    # but most of the time it is a credentials issue
    except Exception:
        # we also set the header
        # see https://fastapi.tiangolo.com/tutorial/security/simple-oauth2/
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not logged in or Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
```

Now we can create a new route in `router.py`:

```python

# router.py
from fastapi import APIRouter, Depends
from typing import Annotated
from app.config import get_firebase_user_from_token

...

@router.get("/userid")
async def get_userid(user: Annotated[dict, Depends(get_firebase_user_from_token)]):
    """gets the firebase connected user"""
    return {"id": user["uid"]}
```

Fastapi will automatically call our `get_firebase_user_from_token` function and save the
result in user. More info here: `https://fastapi.tiangolo.com/tutorial/dependencies/`
