from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from models import get_db
from models.admin import Admin
from models.client import Client

# Configuration de sécurité
# Changez ceci en production!
SECRET_KEY = "votre_clé_secrète_très_sécurisée_changez_moii_enn_productionn"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 20  # 24 heures

# Context pour le hachage des mots de passe
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# OAuth2 scheme pour l'extraction du token
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


def hash_password(password: str) -> str:
    """Hacher un mot de passe"""
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifier un mot de passe"""
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
    """Créer un token JWT"""
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

    return encoded_jwt


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Obtenir l'utilisateur actuel (admin ou client) à partir du token"""

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Impossible de valider les identifiants",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        user_type: str = payload.get("type")

        if user_id is None or user_type is None:
            raise credentials_exception

    except JWTError:
        raise credentials_exception

    # Récupérer l'utilisateur en fonction du type
    if user_type == "admin":
        user = db.query(Admin).filter(Admin.id == int(user_id)).first()
    elif user_type == "client":
        user = db.query(Client).filter(Client.id == int(user_id)).first()
    else:
        raise credentials_exception

    if user is None:
        raise credentials_exception

    return {"user": user, "type": user_type}


def get_current_admin(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> Admin:
    """Obtenir l'admin actuel (uniquement pour les routes admin)"""

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Impossible de valider les identifiants",
        headers={"WWW-Authenticate": "Bearer"},
    )

    forbidden_exception = HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="Accès refusé. Droits administrateur requis"
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        user_type: str = payload.get("type")

        if user_id is None or user_type is None:
            raise credentials_exception

        if user_type != "admin":
            raise forbidden_exception

    except JWTError:
        raise credentials_exception

    admin = db.query(Admin).filter(Admin.id == int(user_id)).first()

    if admin is None:
        raise credentials_exception

    return admin


def get_current_client(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> Client:
    """Obtenir le client actuel (uniquement pour les routes client)"""

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Impossible de valider les identifiants",
        headers={"WWW-Authenticate": "Bearer"},
    )

    forbidden_exception = HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="Accès refusé. Vous devez être connecté en tant que client"
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        user_type: str = payload.get("type")

        if user_id is None or user_type is None:
            raise credentials_exception

        if user_type != "client":
            raise forbidden_exception

    except JWTError:
        raise credentials_exception

    client = db.query(Client).filter(Client.id == int(user_id)).first()

    if client is None:
        raise credentials_exception

    if not client.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Votre compte est désactivé"
        )

    return client
