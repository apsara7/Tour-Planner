const fetch = require('node-fetch');

async function testEndpoint() {
  try {
    console.log('Testing endpoint: http://localhost:4066/api/dashboard/statistics');
    
    const response = await fetch('http://localhost:4066/api/dashboard/statistics');
    console.log('Status:', response.status);
    console.log('Headers:', [...response.headers.entries()]);
    
    const text = await response.text();
    console.log('Response body:', text.substring(0, 200) + '...');
    
    // Try to parse as JSON
    try {
      const json = JSON.parse(text);
      console.log('Parsed JSON:', json);
    } catch (e) {
      console.log('Failed to parse as JSON:', e.message);
    }
  } catch (error) {
    console.error('Error:', error);
  }
}

testEndpoint();