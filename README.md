About WEPopover
===============

WEPopover is an attempt to create a generalized version of the UIPopoverController which is unfortunately only available for the iPad. WEPopover should work on any device with iOS >= 3.2. If you want to use it with iOS < 3.2 you need to implement the @property(nonatomic, readwrite) CGSize contentSizeForViewInPopover for the content view controllers you want to present manually.

The project contains some sample code illustrating the usage of the classes, but the only classes you actually need if you want to use the library reside in the "Popover" group in the project tree.

Please have a look at the UIPopoverController documentation on details of the API.
Additions to the UIPopoverController API include:

- Support for custom background views: specify the WEPopoverContainerViewProperties for the view to use as background. The properties specify the images to use for the stretchable background and the arrows (four directions). It also specifies the margins and the cap sizes for resizing the background. A default image with corresponding arrows are supplied with the project.
- Support for limiting the area to display the popover: implement the protocol WEPopoverParentView for the view you supply to the presentPopover method and implement the - (CGRect)displayAreaForPopover.
- Support for repositioning an existing popover (by passing the need to dismiss it and present a new one). See the 'repositionPopoverFromRect' method in WEPopoverController.


Integrate WEPopover in your project
===================================

The easiest way to integrate WEPopover in your project is build it as a framework. This option have many advantages over make it as subproject, especially if your project uses ARC. To Integrate it follow this easy steps:

1 - Download the WEPopover source code from https://github.com/werner77/WEPopover/

2 - Select as active scheme "WEPopover Framework" for *iPhone/iPad simulator* and build it
![](https://raw.github.com/JoseExposito/WEPopover/WEPopover-as-Framework/screenshots/Integrate_WEPopover_1.png)

3 - Go to the WEPopover source code folder, a "build" folder was generated with the "WEPopover.framework" in

4 - In your project, go to your target and in "Build Phases" tab add the WEPopover.framework by pressing the "+" button, clicking in "Select others" and selecting the framework

![](https://raw.github.com/JoseExposito/WEPopover/WEPopover-as-Framework/screenshots/Integrate_WEPopover_2.png)
![](https://raw.github.com/JoseExposito/WEPopover/WEPopover-as-Framework/screenshots/Integrate_WEPopover_3.png)

5 - In the "Summary" tab, add the WEPopover.framework in the "Linked Frameworks and Libraries" section
![](https://raw.github.com/JoseExposito/WEPopover/WEPopover-as-Framework/screenshots/Integrate_WEPopover_4.png)
