Pod::Spec.new do |s|
s.name			= "StatusBarNotificationCenter"
s.version		= "1.1.3"
s.summary            = "a library that can be used in your application to show customised status bar notification."

s.description		  = <<-DESC
                       During out software development, we want to find a library that can show notification from the status bar,  This project learned many thought from  the popular CWStatusBarNotificationlibrary, but with much cleaner code implementation(in my own option) and fully written in Swift 2.0,  and more extendable, and also it comes with more customisation options, and support multitasking and split view comes with iOS9+ . You can check it if you want to find a custom status bar notification library.
					   Key Feature:
					   1. Support split view in iPad Air and iPad Pro
					   2. Support Concurrency
					   3. Highly customizable
             4. Simple architecture
             **Now, you can let the users interact with the app during the notification is showing by setting the userInteractionEnabled flag of thee StatusBarNotificationCenter configuration, and you can check the latest commit to say how easy it is to add this functionality**
            ![screenshot](screenshots/screenshoot.gif)
                       DESC
s.homepage         = "https://github.com/36Kr-Mobile/StatusBarNotificationCenter.git"
s.license              = 'MIT'
s.author               = { "Shannon Wu" => "inatu@icloud.com" }
s.source               = { :git => "https://github.com/36Kr-Mobile/StatusBarNotificationCenter.git", :tag => s.version.to_s }
s.platform     = :ios, '8.0'
s.requires_arc = true
s.source_files = 'Pod/**/*'
s.frameworks = 'UIKit'
end
