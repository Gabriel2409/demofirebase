import os
import pathlib
from functools import lru_cache
from typing import Annotated, Optional

from dotenv import load_dotenv
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin.auth import verify_id_token
from firebase_admin.firestore import firestore
from pydantic_settings import BaseSettings


# we need to load the env file because it contains the GOOGLE_APPLICATION_CREDENTIALS
basedir = pathlib.Path(__file__).parents[1]
load_dotenv(basedir / ".env")

# use of a simple bearer scheme as auth is handled by firebase and not fastapi
# we set auto_error to False because fastapi incorrectly returns a 403 intead of a 401
# see: https://github.com/tiangolo/fastapi/pull/2120
bearer_scheme = HTTPBearer(auto_error=False)


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


@lru_cache
def get_firestore_client() -> firestore.Client:
    """Gets the firestore client"""
    return firestore.Client()


def get_firebase_user_from_token(
    token: Annotated[Optional[HTTPAuthorizationCredentials], Depends(bearer_scheme)],
) -> Optional[dict]:
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
        # see https://fastapi.tiangolo.com/tutorial/security/simple-oauth2/
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not logged in or Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
