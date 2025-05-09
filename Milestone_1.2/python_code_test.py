import azure.functions as func
import logging
import os

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="myfunction_app")
def myfunction_app(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    api_key = os.environ.get("MY_API_KEY")  

    if api_key:
        return func.HttpResponse(f"Hello, your API key is: {api_key}")
    else:
        return func.HttpResponse(
            "Environment variable MY_API_KEY not found.",
            status_code=500
        )
    


import azure.functions as func
import logging
import os

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="myfunction_app")
def myfunction_app(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    if 'MY_API_KEY' in req.params:
        api_key = os.environ.get("MY_API_KEY")  

        if api_key:
            return func.HttpResponse(f"Hello, The API-KEY secret value is: {api_key}")
        else:
            return func.HttpResponse(
                "Environment variable MY_API_KEY not found.",
                status_code=500
            )
    else:
        return func.HttpResponse(
            "Please pass the MY_API_KEY attribute in the query string.",
            status_code=400
        )