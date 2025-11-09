from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import your routes here
# from routes import your_router

app = FastAPI(
    title="My FastAPI Project",
    description="API documentation",
    version="1.0.0"
)


@app.get("/")
async def root():
    return {"message": "Welcome to FastAPI"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Include your routers here
# app.include_router(your_router, prefix="/api/v1", tags=["your_tag"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
