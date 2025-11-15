from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

# Charger les variables d'environnement
load_dotenv()

# Configuration de la base de données PostgreSQL
# Format: postgresql://username:password@host:port/database_name
SQLALCHEMY_DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:032023@localhost:5432/Ecom_app"
)
print(
    f"🔌 Connexion à la base de données: {SQLALCHEMY_DATABASE_URL.split('@')[1] if '@' in SQLALCHEMY_DATABASE_URL else 'local'}")

# Créer le moteur de base de données
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    echo=False,  # Mettre True pour voir les requêtes SQL
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True  # Vérifier la connexion avant utilisation
)

# Créer la session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base pour les models
Base = declarative_base()

# Dependency pour FastAPI


def get_db():
    """Créer une session de base de données pour chaque requête"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
