const axios = require('axios')

module.exports = async function (context, req) {
  context.log('Processing Azure HTTP Trigger function')

  // Define the OpenAI API endpoint
  const openAiUrl =
    'https://swedencentral.api.cognitive.microsoft.com/openai/deployments/dep-gpt4o-mini/chat/completions?api-version=2024-02-15-preview'

  // Retrieve API key from environment variables (set in Azure Function App settings)
  const apiKey = process.env.OPENAI_API_KEY
  if (!apiKey) {
    context.res = {
      status: 500,
      body: 'Missing API Key. Set OPENAI_API_KEY in environment variables.',
    }
    return
  }

  // Get user prompt from request body
  const userPrompt = req.body?.prompt
  if (!userPrompt) {
    context.res = {
      status: 400,
      body: 'Please provide a prompt in the request body.',
    }
    return
  }

  // Define request body for OpenAI
  const requestBody = {
    messages: [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: userPrompt },
    ],
    max_tokens: 300,
  }

  try {
    // Make the HTTP POST request to OpenAI
    const response = await axios.post(openAiUrl, requestBody, {
      headers: {
        'Content-Type': 'application/json',
        'api-key': apiKey,
      },
    })

    // Return response
    context.res = {
      status: 200,
      body: response.data,
      headers: {
        'Content-Type': 'application/json',
      },
    }
  } catch (error) {
    context.log.error('Error calling OpenAI API:', error.message)

    context.res = {
      status: error.response?.status || 500,
      body: {
        error: error.message,
        details: error.response?.data || 'No additional error details.',
      },
    }
  }
}
