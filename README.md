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
`print("Current App Name:", firebase_admin.get_app().project_id)`

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
