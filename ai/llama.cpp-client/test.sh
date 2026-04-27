#!/bin/sh -ex

# python llama_cpp_openai_client.py -p "what is on lines 5-7 in the file '$(realpath ./llama_cpp_openai_client.py)'?"
#
# echo
#
# python llama_cpp_openai_client.py -p "The task is to change $(realpath ./llama_cpp_openai_client.py) by adding a 'hello Patrik' on line 6. What tools and steps would you use to accomplish this task? Please provide a detailed plan. I just want the plan, don't execute the plan yet."

echo

python llama_cpp_openai_client.py -p "change $(realpath ./llama_cpp_openai_client.py) by adding a 'hello Patrik' on a new line as line 6. Re-read lines 1-10 after the successful updating the file to make sure the change produced the requested outcome. If the change was not made correctly, try again until it is correct."
