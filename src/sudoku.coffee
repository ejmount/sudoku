removeFromArray = (a,e) ->
  while a.indexOf(e) > -1
    i = a.indexOf(e)
    a.splice(i, 1)

createTable = (table, contents) ->
  for r in [0...9]
      row = document.createElement "tr"
      table.appendChild(row)
      for c in [0...9]
        cell = document.createElement("td")
        cell.style.border = "1px solid black"
        cell.style.borderLeftWidth = "3px"    if (c % 3 == 0)
        cell.style.borderRightWidth = "3px"   if (c % 3 == 2)
        cell.style.borderTopWidth = "3px"     if (r % 3 == 0)
        cell.style.borderBottomWidth = "3px"  if (r % 3 == 2)
        cell.style.padding = "0px"
        cell.style.width = "20px"
        cell.style.height = "20px"
        cell.style.textAlign = "center"
        if contents?
          contents(cell)
        row.appendChild(cell)

createBox = (c) ->
  text = document.createElement("input")
  text.setAttribute("size", "1")
  text.onblur = refreshAnswers
  text.setAttribute("value", "")
  c.appendChild(text)

isValidGrid = (G) ->
  G.every (a) ->
    a.every (value) ->
      value == null or parseInt(value) in [1..9]

deducePossibilities = (fixedValues) ->
  if not fixedValues?.length == 9
    throw new RangeError()
  if not (fixedValues.every (x) -> x instanceof Array and x.length == 9)
    throw new RangeError()
  if not isValidGrid(fixedValues)
    throw new RangeError()

  possibilities = ([1..9] for r in [0...9] for c in [0...9])
  for r in [0...9]
    for c in [0...9]
      value = fixedValues[r][c]
      if value == null then continue
      if value in possibilities[r][c]
        possibilities[r][c] = [value]
      for v in [0...9]
        if v != c
          removeFromArray(possibilities[r][v], value) # Remove the value from the row
        if v != r
          removeFromArray(possibilities[v][c], value) # Remove the value from the column
      leftcorner = c - (c % 3)
      topcorner = r - (r % 3) # The coordinates of the top-left corner of the 3x3 block
      for x in [0...3]
        for y in [0...3]
          if not (topcorner+x == r and leftcorner+y == c)
            removeFromArray(possibilities[topcorner+x][leftcorner+y], value)
  finalDeductions = (null for r in [0...9] for c in [0...9])
  for r in [0...9]
    for c in [0...9]
      finalDeductions[r][c] = if possibilities[r][c].length == 1 then possibilities[r][c][0] else null
  return [finalDeductions, possibilities]

refreshAnswers = () ->
  data = document.getElementById("mainTable")
  results = document.getElementById("resultsTable")
  values = (null for r in [0...9] for c in [0...9])

  for r in [0...9]
    for c in [0...9]
      strval =data.children[r].children[c].children[0].value
      values[r][c] = if parseInt(strval) in [1..9] then parseInt(strval) else null
  [answers, possibilities] = deducePossibilities(values)
  prevAnswers = null
  tries = 0
  loop
    prevAnswers = answers
    [answers, possibilities] = deducePossibilities(answers)
    tries++
    break if tries > 50 or prevAnswers.every (A, I) ->
      A.every (n, i) -> answers[I][i] == n

  for r in [0...9]
    for c in [0...9]
      results.children[r].children[c].style.background = "#FFFFFF"
      if possibilities[r][c].length == 1
        results.children[r].children[c].innerHTML = "<b>" + String( possibilities[r][c][0])+"</b>"
      else
        results.children[r].children[c].innerHTML = "<small>" + String( possibilities[r][c].length) + "</small>"

window.onload = () ->
  table = document.getElementById("mainTable")
  createTable(table, createBox)
  results = document.getElementById("resultsTable")
  createTable(results, (c) -> c.innerHTML = 0)