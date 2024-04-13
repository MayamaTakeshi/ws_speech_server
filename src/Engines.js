const config = require('config')

const engines = config.engines

const promises = Object.keys(engines).map(key => {
	return new Promise((resolve, reject) => {
		const engine = engines[key]
    console.log("handling", key)
		import(engine.module)
    .then(m => {
      console.log("resolving", key)
      resolve([
        key,
        m,
        engine.config
      ])
    })
    .catch(e => {
      console.log("rejecting", key)
      reject(e)
    })
	})
})

Promise.all(promises)
.then(res => {
  console.log(res)
})
.catch(e => {
  console.log("error", e)
})
