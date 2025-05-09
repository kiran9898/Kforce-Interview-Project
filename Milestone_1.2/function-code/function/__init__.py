import os
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    api_key = os.getenv("MY_API_KEY", "Not set")
    return func.HttpResponse(f"API Key: {api_key}", status_code=200)