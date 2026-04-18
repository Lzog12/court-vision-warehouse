import time
from functools import wraps


def endpoint_retry(func):

    @wraps(func)
    def wrapper(*args, **kwargs):
        # Parameters controlling request speed and retry limits
        call_delay = 2 #Delay applied before every endpoint call (rate limiting)
        retry_delay = 2 #Initial delay between retries (exponential backoff)
        max_retries = 3 #Total number of attempts (initial + retries)

        # Loop through attempts (1 → max_retries inclusive)
        for attempt in range(1, max_retries+1): # 1 to retries+1 since upper bound is exclusive
            try:
                # Apply delay before calling the endpoint (centralised rate limiting)
                time.sleep(call_delay)

                # Execute original function attempt
                return func(*args, **kwargs)
            
            except Exception as e:
                # If the attempt fails and we still have retries left    
                if attempt < max_retries:
                    print(f"Attempt {attempt} failed. Retrying for attempt {attempt+1}...")

                    # Wait before retrying (backoff)
                    time.sleep(retry_delay)

                    # Increase delay for next retry (exponential backoff)
                    retry_delay *= 2
                else:
                    # If we reach here, it means:
                    # - An exception occurred
                    # - AND this was the final attempt (attempt == max_retries)
                    # So we raise the error and stop execution
                    raise RuntimeError(f'ERROR - FUNCTION: {func.__name__} {e}') from e

    return wrapper