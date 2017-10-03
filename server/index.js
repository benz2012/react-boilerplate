const express = require('express')

const hotMiddleware = require('./hot')

// Globals
const app = express()


// Move to sparate server file, load only in development
if (process.env.NODE_ENV !== 'production') {
  hotMiddleware(app)
}


// Routes
app.use(express.static(`${process.cwd()}/public`))


// Start Server
const port = process.env.PORT || 8080
app.listen(port, () => {
  console.log(`\n\nserver listening on port ${port}\n`)
})
