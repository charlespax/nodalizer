#!/usr/bin/env python3


import npyscreen

class App(npyscreen.StandardApp):
    def onStart(self):
        self.addForm("MAIN", MainForm, name="Hello Medium!")

class MainForm(npyscreen.ActionForm):
    # Constructor
    def create(self):
        # Add TitleText sidget to the form
        self.title = self.add(npyscreen.TitleText, name="TitleText", value="Hello World!")
    # Override method that triggers when you click "ok"
    def on_ok(self):
        self.parentApp.setNextForm(None)
    # Override method that triggers when you click "cancel"
    def on_cancel(self):
        self.title.value = "Hello World!"

MyApp = App()
# npyscreen has a bug in Python 3.7. The workaround is to catch the
# StopIteration errors. Otherwise, this script will exit.
try:
    MyApp.run()
except StopIteration:
    print("ERROR")

