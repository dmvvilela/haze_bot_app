# Gemini AI Setup

To enable AI functionality in HazeBot, you need to add your Gemini API key.

## Steps:

1. **Get a Gemini API Key:**
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a new API key
   - Copy the key

2. **Add the API Key:**
   - Copy `.env.example` to `.env`: `cp .env.example .env`
   - Open `.env` file
   - Replace `your_gemini_api_key_here` with your actual API key
   - Example: `GEMINI_API_KEY=AIzaSyC1234567890abcdefghijklmnopqrstuvwxyz`

3. **Test the AI:**
   - Run the app
   - Tap the robot brain icon (🤖) to get AI responses
   - Start a timer to see AI motivation messages

## Features:

- **Emotion Responses**: AI generates funny responses based on robot's current emotion
- **Timer Motivation**: Encouraging messages when you start a timer
- **Timer Completion**: Celebratory messages when timer finishes
- **Fallback Messages**: Works offline with pre-written responses if API fails

## Note:
The app works perfectly without the API key - it just uses the built-in fallback responses instead of AI-generated ones! 