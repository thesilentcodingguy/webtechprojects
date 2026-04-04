from openai import OpenAI
client = OpenAI(
    base_url="https://gen.pollinations.ai/v1",
    api_key="" 
)
response = client.chat.completions.create(
    model="openai",
    messages=[
        {
            "role": "system", 
            "content": "You are a Flutter/Dart expert. Output ONLY the raw source code for a single main.dart file. Do not include markdown code blocks (```dart), do not include explanations, and do not include any text before or after the code. Ensure the code is a complete, runnable app."
        },
        {
            "role": "user", 
            "content": ""
        }
    ]
)
print(response.choices[0].message.content)

