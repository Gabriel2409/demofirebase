from app.router import router
from fastapi import FastAPI

import firebase_admin
from fastapi.middleware.cors import CORSMiddleware

# importing config will also call load_dotenv to get GOOGLE_APPLICATION_CREDENTIALS
from app.config import get_settings


app = FastAPI()
app.include_router(router)
settings = get_settings()
origins = [settings.frontend_url]

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
