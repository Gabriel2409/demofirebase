from app.router import router
from fastapi import FastAPI

import firebase_admin
from dotenv import load_dotenv
import pathlib

from fastapi.middleware.cors import CORSMiddleware
import os

# we need to load the env file because it contains the GOOGLE_APPLICATION_CREDENTIALS
basedir = pathlib.Path(__file__).parents[1]
load_dotenv(basedir / ".env")

app = FastAPI()
app.include_router(router)
origins = [os.getenv("FRONTEND_URL", "")]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


firebase_admin.initialize_app()

# Debug, check app is correctly
print("Current App Name:", firebase_admin.get_app().project_id)
print(os.getenv("FRONTEND_URL"))
