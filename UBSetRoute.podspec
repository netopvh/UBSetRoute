#
# Be sure to run `pod lib lint UBSetRoute.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UBSetRoute'
  s.version          = '0.2.2'
  s.summary          = 'UBSetRoute.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Pod with UI Set Route.
                       DESC

  s.homepage         = 'http://git.usemobile.com.br/libs-iOS/use-blue/set-route'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tulio de Oliveira Parreiras' => 'tulio@usemobile.xyz' }
  s.source           = { :git => 'http://git.usemobile.com.br/libs-iOS/use-blue/set-route.git', :tag => s.version.to_s }
  s.swift_version    = '4.2'
  s.ios.deployment_target = '10.0'

  s.source_files = 'UBSetRoute/Classes/**/*'

#  s.resource_bundles = {
#    'UBSetRoute' => ['UBSetRoute/Classes/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}']
#  }
  s.resource_bundles = {
#      'UBSetRoute' => ['UBSetRoute/Assets/Media.xcassets']
      'UBSetRoute' => [
          'UBSetRoute/Assets/*.{png,jpeg,jpg,xcassets}'
#          'UBSetRoute/Classes/View/RouteView/*.xib'
          ]
  }
#  s.resources = "UBSetRoute/Classes/View/RouteView/*.xib"
  s.static_framework = true
  s.dependency 'GoogleMaps'
  s.frameworks = 'UIKit'
  
end

##'UBSelectTravelOptions' => ['UBSelectTravelOptions/Classes/**/*.xib']
##
## Be sure to run `pod lib lint USE_GoogleAPI.podspec' to ensure this is a
## valid spec before submitting.
##
## Any lines starting with a # are optional, but their use is encouraged
## To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
##
#
#Pod::Spec.new do |s|
#    s.name             = 'USE_GoogleAPI'
#    s.version          = '0.1.0'
#    s.summary          = 'A short description of USE_GoogleAPI.'
#
#    # This description is used to generate tags and improve search results.
#    #   * Think: What does it do? Why did you write it? What is the focus?
#    #   * Try to keep it short, snappy and to the point.
#    #   * Write the description between the DESC delimiters below.
#    #   * Finally, don't worry about the indent, CocoaPods strips it!
#
#    s.description      = <<-DESC
#    TODO: Add long description of the pod here.
#    DESC
#
#    s.homepage         = 'https://github.com/Tulio Parreiras/USE_GoogleAPI'
#    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
#    s.license          = { :type => 'MIT', :file => 'LICENSE' }
#    s.author           = { 'Tulio Parreiras' => 'tulio@usemobile.xyz' }
#    s.source           = { :git => 'https://github.com/Tulio Parreiras/USE_GoogleAPI.git', :tag => s.version.to_s }
#    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
#
#    s.ios.deployment_target = '8.0'
#
#    s.source_files = 'USE_GoogleAPI/Classes/**/*'
#
#    # s.resource_bundles = {
#    #   'USE_GoogleAPI' => ['USE_GoogleAPI/Assets/*.png']
#    # }
#
#    # s.public_header_files = 'Pod/Classes/**/*.h'
#    # s.frameworks = 'UIKit', 'MapKit'
#    # s.dependency 'AFNetworking', '~> 2.3'
#end
