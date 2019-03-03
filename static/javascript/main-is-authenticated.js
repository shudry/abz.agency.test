// Generated by CoffeeScript 1.12.7
(function() {
  var $, AJAXEmployeesManager;

  $ = jQuery;

  AJAXEmployeesManager = (function() {
    var appendElementLoadMore, appendElementToDOM, shownFirstWorkersId;

    shownFirstWorkersId = {};

    function AJAXEmployeesManager(firstCount, secondCount) {
      this.firstCount = firstCount;
      this.secondCount = secondCount;
    }

    AJAXEmployeesManager.prototype.getEmployee = function(url, requestDone) {
      var request;
      request = $.ajax({
        url: url,
        type: "GET"
      });
      request.fail(this.AJAXerrorGetWorkers);
      return request.done(requestDone);
    };

    AJAXEmployeesManager.prototype.AJAXerrorGetWorkers = function(jqXHR, textStatus, errorThrown) {
      return console.log("Error: " + jqXHR + ", " + textStatus + ", " + errorThrown);
    };

    appendElementToDOM = function(element) {
      var html;
      return html = "<div class=\"employee\" id=\"employee-id-" + element.id + "\">\n    <div class=\"row\">\n        <div class=\"col-md-1 employee-image\"><i class=\"fas fa-user-tie fa-2x\"></i></div>\n        <div class=\"col-md-4\">\n          <p>" + element.name + "</p>\n        </div>\n        <div class=\"col-md-2\">\n          <p>" + element.work_position + "</p>\n        </div>\n        <div class=\"col-md-2\">\n          <p>" + element.wage + "</p>\n        </div>\n        <div class=\"col-md-2\">\n          <p>" + element.date_join + "</p>\n        </div>\n        <div class=\"col-md-1\">\n          <p>" + element.id + "</p>\n        </div>\n    </div>\n</div>";
    };

    appendElementLoadMore = function(element_chief) {
      var html;
      return html = "<div class=\"employee load-more-empl\" id=\"employee-load-more-" + element_chief + "\">\n    <div class=\"row justify-content-md-center\">\n        <div class=\"col-md-auto\">\n            <a href=\"#load-more\" class=\"employee-load-more-link btn btn-default\" id=\"" + element_chief + "\">Загрузити ще ...</a>\n        </div>\n    </div>\n</div>";
    };

    AJAXEmployeesManager.prototype.showFirstHierarchy = function(count, urlNext) {
      var thisContext, url;
      url = urlNext || ("/employee/withoutchief/?limit=" + count);
      thisContext = this;
      return this.getEmployee(url, function(data, textStatus, jqXHR) {
        var element, i, len, ref;
        if (data.results || data.count > 0 || !data.next) {
          $("#employee-load-more-first-loads").remove();
        }
        ref = data.results;
        for (i = 0, len = ref.length; i < len; i++) {
          element = ref[i];
          if (!shownFirstWorkersId[element.id]) {
            shownFirstWorkersId[element.id] = {
              self: element,
              subordinates: {}
            };
            $(".container-workers").append(appendElementToDOM(element));
            thisContext.showSecondHierarchy(element.id, null, thisContext.secondCount);
          }
        }
        if (data.next) {
          $(".container-workers").append(appendElementLoadMore("first-loads"));
          return $("#employee-load-more-first-loads").find("a").click(function(e) {
            return thisContext.showFirstHierarchy(count, data.next);
          });
        }
      });
    };

    AJAXEmployeesManager.prototype.showSecondHierarchy = function(elementID, urlNext, count) {
      var thisContext, url;
      url = urlNext || ("/employee/" + elementID + "/subordinates/?limit=" + count);
      thisContext = this;
      return this.getEmployee(url, function(data, textStatus, jqXHR) {
        var employee, i, len, ref;
        if (data.results || data.count > 0 || !data.next) {
          $("#employee-load-more-" + elementID).remove();
        }
        ref = data.results;
        for (i = 0, len = ref.length; i < len; i++) {
          employee = ref[i];
          if (!shownFirstWorkersId[employee.chief].subordinates[employee.id]) {
            shownFirstWorkersId[employee.chief].subordinates[employee.id] = employee;
            $("#employee-id-" + employee.chief).append(appendElementToDOM(employee));
          }
        }
        if (data.next) {
          $("#employee-id-" + elementID).append(appendElementLoadMore(elementID));
          return $("#employee-load-more-" + elementID).find("a").click(function(e) {
            return thisContext.showSecondHierarchy(e.target.id, data.next, thisContext.secondCount);
          });
        }
      });
    };

    AJAXEmployeesManager.prototype.showEmployees = function() {
      return this.showFirstHierarchy(this.firstCount);
    };

    AJAXEmployeesManager.prototype.showListWorkers = function() {
      return console.log(shownFirstWorkersId);
    };

    return AJAXEmployeesManager;

  })();

  $(document).ready(function() {
    var me2;
    me2 = new AJAXEmployeesManager(40, 10);
    return me2.showEmployees();
  });

}).call(this);
