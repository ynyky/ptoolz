import os
import sys
from anthropic import Anthropic

# Get the first command-line argument
user_input = sys.argv[1]

# Initialize client
client = Anthropic(
    api_key=os.environ.get("ANTHROPIC_API_KEY")
)

# Send message
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    messages=[
        {"role": "user", "content": user_input}
    ],
    max_tokens=1024,
)

print(message.content)