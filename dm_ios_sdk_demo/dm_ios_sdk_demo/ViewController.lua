
local viewController = { }



function viewController.viewDidLoad(cls)

    print("hello ViewController",str)
    print(debug.dump(cls))

    local ctx = objc.context:create()
    local ret= ctx:sendMesg(cls,"Test:","test sun")


end

function viewController.imgclick(cls,str)

   print("hello ViewController.imgclick", str)
  local ctx = objc.context:create()
  local ret= ctx:sendMesg(cls,"Test:","test sun")


end

function viewController.Test(cls,str)

    print("hello viewController.Test", str)

   

end


ViewController = viewController

ViewController_Aspect = {
    {
        event = "viewDidLoad",--objc
        handler = "viewDidLoad",--lua
        type = 0
    },

    {
        event = "imgclick",
        handler = "imgclick",
        type = 2
    },
    {
        event = "Test:",
        handler = "Test",
        type = 2
    },
}
