const fs = require('fs/promises')
const path = require('path')

const postcss = require('postcss')
const scss = require('postcss-scss')
const sorting = require('postcss-sorting')

const rootDir = path.join(process.cwd(), 'app/assets/stylesheets')
const sortingOptions = {
  'properties-order': 'alphabetical',
  'unspecified-properties-position': 'bottom',
  order: [
    'custom-properties',
    'dollar-variables',
    'declarations',
    'at-rules',
    'rules'
  ]
}

async function walk(dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true })
  const files = []

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name)

    if (entry.isDirectory()) {
      files.push(...await walk(fullPath))
      continue
    }

    if (entry.isFile() && fullPath.endsWith('.scss')) {
      files.push(fullPath)
    }
  }

  return files
}

async function sortFile(filePath) {
  const source = await fs.readFile(filePath, 'utf8')
  const result = await postcss([sorting(sortingOptions)]).process(source, {
    from: filePath,
    syntax: scss
  })

  if (result.css !== source) {
    await fs.writeFile(filePath, result.css)
    return true
  }

  return false
}

async function main() {
  const files = await walk(rootDir)
  let updated = 0

  for (const filePath of files) {
    if (await sortFile(filePath)) {
      updated += 1
    }
  }

  console.log(`Sorted ${updated} of ${files.length} SCSS files.`)
}

main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
