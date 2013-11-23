Testing visual appearance with Cucumber + Watir
===============================================

Example on how to test visual appearance of web pages using Cucumber + Watir

See blog post at http://codeforhire.com/2013/11/23/testing-visual-appearance-with-cucumber-watir/


Running the tests
-----------------

Just run `cucumber`.

The test will likely fail due to browser rendering differences.  Compare the resulting images under the `output` directory.  See the blog post for details.

Gems required for running the test:
  * cucumber
  * watir-webdriver
  * oily_png

Additionally you need the [chromedriver][1] executable somewhere on your path.


[1]: http://code.google.com/p/selenium/wiki/ChromeDriver

