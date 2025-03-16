from kybra import query

@query
def greet() -> str:
    return "Hello from the backend!"
