# TESTING THE DEBUGGER 

print(__name__)

# def clean_numbers(values):
#     cleaned = []

#     for v in values:
#         if isinstance(v, str):
#             v = int(v)

#         cleaned.append(v)

#     return cleaned


# def calculate_average(nums):
#     total = 0
    
#     for n in nums:
#         total += n

#     count = len(nums)

#     # Put a breakpoint here
#     average = total / count

#     return average


# def main():
#     raw_data = [10, "20", 30, "40", None]   # Intentional bug: None

#     numbers = clean_numbers(raw_data)

#     result = calculate_average(numbers)

#     print(f"Average: {result}")


# if __name__ == "__main__":
#     main()