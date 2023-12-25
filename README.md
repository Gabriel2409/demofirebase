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
