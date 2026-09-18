import requests

def fetch_posts(url , timeout=10):
    try:
        response = requests.get(f"{url}/posts",timeout=timeout)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.ConnectionError:
        print("error : could not connect the api")
        return []
    except requests.exceptions.Timeout:
        print("error : api request timed out")
        return []

def fetch_users(url , timeout=10):
    try:
        response = requests.get(f"{url}/users" , timeout = timeout)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.ConnectionError:
        print("error : could not connect to api")
        return []
    except requests.exceptions.Timeout:
        print("error : api request timed out")
        return []
