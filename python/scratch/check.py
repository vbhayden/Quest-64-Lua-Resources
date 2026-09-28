import time
import asyncio

async def wait_for_dict():
    time.sleep(5)
    
    return {"hello": 123}

async def main():
    
    value = await wait_for_dict()
    print(value)
    
asyncio.run(main())
