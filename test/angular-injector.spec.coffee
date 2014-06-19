require 'coffee-errors'

chai = require 'chai'
sinon = require 'sinon'
# using compiled JavaScript file here to be sure module works
injector = require '../lib/angular-injector.js'

expect = chai.expect
chai.use require 'sinon-chai'

suite = (token = 'ng') ->
  describe "using `#{token}` token", ->
    results = null

    before ->
      results = injector.annotate """
        #{token} = function($scope, foo) {}
        function #{token}($scope, foo) {}
        var #{token}1 = #{token}.toString();

        __#{token}__(1, 2);

        var controller = #{token}(function($scope, foo, bar) {
          console.log(foo, bar);
        });

        app.service('foo', #{token}(function controller($scope, foo, bar) {
          console.log(foo, bar);
        }));

        app.service('bar', #{token}(function() {
          console.log('no arguments...');
        }));
      """, {token}

    it 'produces valid results', ->
      expect(results).to.equal """
        #{token} = function($scope, foo) {}
        function #{token}($scope, foo) {}
        var #{token}1 = #{token}.toString();

        __#{token}__(1, 2);

        var controller = ['$scope', 'foo', 'bar', function($scope, foo, bar) {
          console.log(foo, bar);
        }];

        app.service('foo', ['$scope', 'foo', 'bar', function controller($scope, foo, bar) {
          console.log(foo, bar);
        }]);

        app.service('bar', function() {
          console.log('no arguments...');
        });
      """

    describe 'using nested injections', ->
      it 'annotates both injections', ->
        nested = injector.annotate """
          var controller = #{token}(function($rootScope, foo){
            foo.inject(#{token}(function($scope, bar){
              console.log(foo, bar);
            }));
          });
        """, {token}

        expect(nested).to.equal """
          var controller = ['$rootScope', 'foo', function($rootScope, foo){
            foo.inject(['$scope', 'bar', function($scope, bar){
              console.log(foo, bar);
            }]);
          }];
        """

describe 'angular-injector', ->
  suite()
  suite 'ƒ'
