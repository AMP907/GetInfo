import nigui, strutils, osproc

const
    userFields = ["User name",
                  "Full Name",
                  "Account active",
                  "Account expires",
                  "Password last set"]
    
    userNotFound = "The user name could not be found"
    options: set[ProcessOption] = {poStdErrToStdOut,poUsePath,poEvalCommand,poDemon}

proc getDomainUsers(): seq[string] =
    result = execProcess("net user /domain",options=options).splitWhitespace()[17..^5]

proc findUser(userName: string, userList: seq[string]): seq[string] =
    result = @[]
    for user in userList:
        if username.toLowerAscii in user.toLowerAscii:
            result.add(user)

proc getUser(userName: string): seq[string] =
    result = @[]
    let execResult = execProcess("net user $# /domain" % userName, options=options)
    if userNotFound in execResult:
        let found = findUser(userName, getDomainUsers())
        case found.len:
        of 0:
            result.add("No Matching Users Found")
        of 1:
            for line in getUser(found[0]):
                result.add(line)
        else:
            result.add("More than one matching user:")
            result.add("----------------------------")
            for i,user in found:
                result.add($i & ". " & user)
    else:
        for line in execResult.split("\n"):
            for field in userFields:
                if field in line:
                    result.add(line)

#####  GUI  #####

app.init()

var window = newWindow("Get User Information")
window.width =  400
window.height = 400

var mainContainer = newLayoutContainer(Layout_Vertical)
mainContainer.padding = 15
window.add(mainContainer)

var topContainer = newLayoutContainer(Layout_Horizontal)
mainContainer.add(topContainer)

var label = newLabel("Enter Username:")
topContainer.add(label)

var textBox = newTextBox("")
topContainer.add(textBox)

var button = newButton("Search")
topContainer.add(button)

var bottomContainer = newLayoutContainer(Layout_Vertical)
mainContainer.add(bottomContainer)

var textArea = newTextArea()
textArea.editable = false
bottomContainer.add(textArea)

#####  EVENTS  #####

proc updateText: void =
    textArea.text = ""
    for line in getUser(textBox.text):
        textArea.addLine(line)

button.onClick = proc(event:ClickEvent) =
    updateText()

textBox.onKeyDown = proc(event: ControlKeyEvent) =
    if event.key == Key_Return:
        updateText()

#####  RUN PROGRAM  #####

window.show()
textBox.focus()
app.run()