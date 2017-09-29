const express = require('express')


// Globals
const app = express()


// Routes
app.use(express.static(__dirname + '/public'))


// Start Server
const port = process.env.PORT || 8080
app.listen(port, () => {
  console.log(`listening on port ${port}`)
})
