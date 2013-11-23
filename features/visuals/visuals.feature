@visual
Feature:  Visual appearance of codeforhire.com
 
  Background:
    Given my browser resolution is 1024x600

  Scenario:  Visual appearance of codeforhire.com banner
     When I open "http://codeforhire.com/"
     Then I should see the contents of "codeforhire.png"

