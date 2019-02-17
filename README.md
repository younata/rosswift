# RosSwift

Swift tooling for [ROS](https://ros.org).

This is another client library for ROS, though it's currently separate (... mostly) from the ROS tooling. It reimplements the underlying ROS communication methods, and provides an API similar to what you'd use in roscpp or rospy, but swifty.

Because I dislike both C++ and Python, so I spent months shaving this yak.

# Packages

## Ros

This is the Ros api. Currently in progress.

## MessageGenerator

This is a tool for generating Swift code from .msg files. Run it as `swift run MessageGenerator -e /path/to/ros/environment path/to/ros/message/to/generate`, this outputs the code to standard output, you can pipe it to wherever you want it.

