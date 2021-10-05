export const clearDOM = () => {
  document.body.innerHTML = ''
}

export const renderDOM = (body: string) => {
  document.body.innerHTML = body
}
