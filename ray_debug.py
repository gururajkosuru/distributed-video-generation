#!/usr/bin/env python3
import ray
import time
import os

# Connect to Ray cluster
ray_address = os.getenv("RAY_ADDRESS", "ray://ray-head-service:10001")
print(f"Connecting to Ray at {ray_address}")

try:
    ray.init(address=ray_address, ignore_reinit_error=True)
    print("✅ Ray connected successfully")
    
    # Define a simple remote function
    @ray.remote
    def simple_task(x):
        print(f"Task running on worker with input: {x}")
        import time
        time.sleep(2)  # Simulate work
        return f"Task completed: {x * 2}"
    
    # Submit task
    print("📤 Submitting simple task...")
    future = simple_task.remote(42)
    
    # Wait for result with timeout
    print("⏳ Waiting for result...")
    try:
        result = ray.get(future, timeout=30)
        print(f"✅ Task completed: {result}")
    except ray.exceptions.GetTimeoutError:
        print("❌ Task timed out after 30 seconds")
    except Exception as e:
        print(f"❌ Task failed: {e}")
        
    # Check cluster status
    print("\n🔧 Cluster Resources:")
    print(ray.cluster_resources())
    
except Exception as e:
    print(f"❌ Ray connection failed: {e}")