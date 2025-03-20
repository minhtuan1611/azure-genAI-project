const { app } = require('@azure/functions')
const fetch = require('node-fetch')

app.http('httpTrigger', {
  methods: ['GET', 'POST'],
  authLevel: 'anonymous',
  handler: async (request, context) => {
    context.log(`Http function processed request for url "${request.url}"`)

    const apiKey = process.env.OPENAI_API_KEY

    if (!apiKey) {
      context.log('API key is missing!')
      return { status: 500, body: 'API key is missing' }
    }

    const openaiRequestBody = {
      messages: [
        { role: 'system', content: 'You are a helpful assistant.' },
        { role: 'user', content: 'Hello, how many days in a month?' },
      ],
      max_tokens: 300,
    }

    // OpenAI API URL
    const openaiUrl =
      'https://tuan-m8focyel-eastus2.openai.azure.com/openai/deployments/gpt-4o-mini-test/chat/completions?api-version=2025-01-01-preview'

    try {
      // Make the POST request to OpenAI API
      const response = await fetch(openaiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify(openaiRequestBody),
      })

      if (!response.ok) {
        context.log(`Error calling OpenAI API: ${response.statusText}`)
        return { status: 500, body: 'Error calling OpenAI API' }
      }

      const data = await response.json()

      context.log('OpenAI API response:', data)
      return { body: `Response from AI: ${data.choices[0].message.content}` }
    } catch (error) {
      context.log('Error during OpenAI API call:', error)
      return { status: 500, body: 'Failed to call OpenAI API' }
    }
  },
})
