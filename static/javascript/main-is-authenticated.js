// Generated by CoffeeScript 1.9.3
(function() {
  var $, AJAXEmployeesManager, PopUpWindowManager,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $ = jQuery;

  AJAXEmployeesManager = (function() {
    var appendElementLoadMore, shownFirstWorkersId;

    shownFirstWorkersId = {};

    function AJAXEmployeesManager(firstCount, secondCount, managerPopUp1) {
      this.firstCount = firstCount;
      this.secondCount = secondCount;
      this.managerPopUp = managerPopUp1;
    }

    AJAXEmployeesManager.prototype.getEmployee = function(url, requestDone) {
      var request, thisContext;
      thisContext = this;
      request = $.ajax({
        url: url,
        type: "GET"
      });
      request.done(requestDone);
      return request.fail(function(jqXHR, textStatus, errorThrown) {
        return thisContext.showErrorAlert(errorThrown);
      });
    };

    AJAXEmployeesManager.prototype.getLocationPathname = function(href) {
      var l;
      l = document.createElement("a");
      l.href = href;
      return l.pathname + l.search;
    };

    AJAXEmployeesManager.prototype.appendElementToDOM = function(container, element, id) {
      var html, idElement, thisContext;
      thisContext = this;
      idElement = id ? "employee-" + id + "-" + element.id : "employee-id-" + element.id;
      html = "<div class=\"employee\" id=\"" + idElement + "\">\n    <div class=\"row\" id=\"" + element.id + "\">\n        <div class=\"col-md-1 employee-image\"><i class=\"fas fa-user-tie fa-2x\"></i></div>\n        <div class=\"col-md-3\">\n          <p>" + element.name + "</p>\n        </div>\n        <div class=\"col-md-2\">\n          <p>" + element.work_position + "</p>\n        </div>\n        <div class=\"col-md-2\">\n          <p>" + element.wage + "</p>\n        </div>\n        <div class=\"col-md-2\">\n          <p>" + element.date_join + "</p>\n        </div>\n        <div class=\"col-md-2\">\n          <p>" + element.id + "</p>\n        </div>\n    </div>\n</div>";
      $(container).append(html);
      return $("#" + idElement + " > .row").click(function(e) {
        return thisContext.managerPopUp.show(e.currentTarget.id);
      });
    };

    appendElementLoadMore = function(element_chief) {
      var html;
      return html = "<div class=\"employee load-more-empl\" id=\"employee-load-more-" + element_chief + "\">\n    <div class=\"row justify-content-md-center\">\n        <div class=\"col-md-auto\">\n            <a href=\"#load-more\" class=\"employee-load-more-link btn btn-default\" id=\"" + element_chief + "\">Загрузити ще ...</a>\n        </div>\n    </div>\n</div>";
    };

    AJAXEmployeesManager.prototype.showFirstHierarchy = function(count, urlNext, isSearchResult) {
      var sorted, thisContext, url;
      if (isSearchResult == null) {
        isSearchResult = false;
      }
      sorted = encodeURIComponent($('#select-sorted-by').val());
      url = urlNext || ("/employee/withoutchief/?limit=" + count + "&sorted=" + sorted);
      thisContext = this;
      return this.getEmployee(url, function(data, textStatus, jqXHR) {
        var element, j, len, ref;
        if (data.results || data.count > 0 || !data.next) {
          $("#employee-load-more-first-loads").remove();
        }
        if (!isSearchResult) {
          if (Object.keys(shownFirstWorkersId).length === 0) {
            if (!data.results || data.count === 0) {
              thisContext.showNotFoundAlert();
            }
          }
        } else {
          if (!data.results || data.count === 0) {
            thisContext.showNotFoundAlert();
          }
        }
        ref = data.results;
        for (j = 0, len = ref.length; j < len; j++) {
          element = ref[j];
          if (!isSearchResult) {
            if (!shownFirstWorkersId[element.id]) {
              shownFirstWorkersId[element.id] = {
                self: element,
                subordinates: {}
              };
              thisContext.appendElementToDOM(".container-workers", element);
              thisContext.showSecondHierarchy(element.id, null, thisContext.secondCount);
            }
          } else {
            thisContext.appendElementToDOM(".container-workers", element, "search-result");
          }
        }
        if (data.next) {
          $(".container-workers").append(appendElementLoadMore("first-loads"));
          return $("#employee-load-more-first-loads").find("a").click(function(e) {
            return thisContext.showFirstHierarchy(count, thisContext.getLocationPathname(data.next), isSearchResult);
          });
        }
      });
    };

    AJAXEmployeesManager.prototype.showSecondHierarchy = function(elementID, urlNext, count, doUseGlobalArray) {
      var sorted, thisContext, url;
      if (doUseGlobalArray == null) {
        doUseGlobalArray = true;
      }
      sorted = encodeURIComponent($('#select-sorted-by').val());
      url = urlNext || ("/employee/" + elementID + "/subordinates/?limit=" + count + "&sorted=" + sorted);
      thisContext = this;
      return this.getEmployee(url, function(data, textStatus, jqXHR) {
        var employee, j, len, ref;
        if (data.results || data.count > 0 || !data.next) {
          $("#employee-load-more-" + elementID).remove();
        }
        ref = data.results;
        for (j = 0, len = ref.length; j < len; j++) {
          employee = ref[j];
          if (doUseGlobalArray) {
            if (!shownFirstWorkersId[employee.chief].subordinates[employee.id]) {
              shownFirstWorkersId[employee.chief].subordinates[employee.id] = employee;
              thisContext.appendElementToDOM("#employee-id-" + employee.chief, employee);
            }
          } else {
            thisContext.appendElementToDOM("#employee-id-" + elementID, employee);
          }
        }
        if (data.next) {
          $("#employee-id-" + elementID).append(appendElementLoadMore(elementID));
          return $("#employee-load-more-" + elementID).find("a").click(function(e) {
            return thisContext.showSecondHierarchy(e.target.id, thisContext.getLocationPathname(data.next), thisContext.secondCount, doUseGlobalArray);
          });
        }
      });
    };

    AJAXEmployeesManager.prototype.hideAllEmployeesInContainer = function() {
      var element, j, len, ref;
      ref = Object.keys(shownFirstWorkersId);
      for (j = 0, len = ref.length; j < len; j++) {
        element = ref[j];
        $("#employee-id-" + element).css({
          display: "none"
        });
      }
      return $("#employee-load-more-first-loads").css({
        display: "none"
      });
    };

    AJAXEmployeesManager.prototype.showAllEmployeesInContainer = function() {
      var element, j, len, ref;
      this.clearContainer();
      ref = Object.keys(shownFirstWorkersId);
      for (j = 0, len = ref.length; j < len; j++) {
        element = ref[j];
        $("#employee-id-" + element).css({
          display: "block"
        });
      }
      return $("#employee-load-more-first-loads").css({
        display: "block"
      });
    };

    AJAXEmployeesManager.prototype.showNotFoundAlert = function() {
      this.clearContainer();
      return $('#not-found-employees-warning').css({
        display: "block"
      });
    };

    AJAXEmployeesManager.prototype.hideNotFoundAlert = function() {
      return $('#not-found-employees-warning').css({
        display: "none"
      });
    };

    AJAXEmployeesManager.prototype.showErrorAlert = function(errorText) {
      this.clearContainer();
      $('#alert_server_error').css({
        display: "block"
      });
      return $('#alert_server_error #error_message').text(errorText);
    };

    AJAXEmployeesManager.prototype.hideErrorAlert = function() {
      return $('#alert_server_error').css({
        display: "none"
      });
    };

    AJAXEmployeesManager.prototype.removeSearchResults = function() {
      return $('[id^="employee-search-result-"]').remove();
    };

    AJAXEmployeesManager.prototype.clearContainer = function() {
      this.removeSearchResults();
      this.hideNotFoundAlert();
      this.hideErrorAlert();
      return this.hideAllEmployeesInContainer();
    };

    AJAXEmployeesManager.prototype.removeEmployees = function() {
      var element, j, len, ref;
      ref = Object.keys(shownFirstWorkersId);
      for (j = 0, len = ref.length; j < len; j++) {
        element = ref[j];
        $("#employee-id-" + element).remove();
      }
      return shownFirstWorkersId = {};
    };

    AJAXEmployeesManager.prototype.initEmployees = function() {
      return this.showFirstHierarchy(this.firstCount);
    };

    AJAXEmployeesManager.prototype.getListWorkers = function() {
      return shownFirstWorkersId;
    };

    return AJAXEmployeesManager;

  })();

  PopUpWindowManager = (function() {
    var chiefBlock, closePopUpArea, employeeBlock, employeesTreeBlock, errorBlock, mainContainer, paddingColEmployee;

    mainContainer = "#pop-up-container";

    closePopUpArea = mainContainer + " #backgroud-close-block";

    errorBlock = mainContainer + " #error-pop-up-block";

    employeeBlock = mainContainer + " #info-employee";

    chiefBlock = mainContainer + " #info-chief-employee";

    employeesTreeBlock = mainContainer + " #tree-view-employees";

    paddingColEmployee = employeeBlock + " > .padding-col-employee";

    function PopUpWindowManager() {
      var thisContext;
      thisContext = this;
      $(closePopUpArea).click(function() {
        return thisContext.hide();
      });
    }

    PopUpWindowManager.prototype.hide = function() {
      $(mainContainer).css({
        display: "none"
      });
      $(employeeBlock).css({
        display: "none"
      });
      $(chiefBlock).css({
        display: "none"
      });
      $(employeesTreeBlock).css({
        display: "none"
      });
      return $(errorBlock).css({
        display: "none"
      });
    };

    PopUpWindowManager.prototype.show = function(employeeId) {
      var request, thisContext;
      thisContext = this;
      request = $.ajax({
        url: "/employee/" + employeeId + "/",
        type: "GET"
      });
      request.done(function(data, textStatus, jqXHR) {
        $(mainContainer).css({
          display: "block"
        });
        if (jqXHR.status === 200) {
          thisContext._showEmployee(data);
          thisContext._showEmployeesTree(data.id);
          if (data.chief) {
            thisContext._showChief(data.chief);
            return $(paddingColEmployee).css({
              display: "block"
            });
          } else {
            return $(paddingColEmployee).css({
              display: "none"
            });
          }
        } else {

        }
      });
      return request.fail(function(jqXHR, textStatus, errorThrown) {
        $(mainContainer).css({
          display: "block"
        });
        return thisContext.showError();
      });
    };

    PopUpWindowManager.prototype.showError = function(textError) {
      var element;
      if (textError == null) {
        textError = "Виникла помилка. Спробуйте ще раз";
      }
      element = $(errorBlock);
      element.find("p").text(textError);
      return element.css({
        display: "flex"
      });
    };

    PopUpWindowManager.prototype._showEmployee = function(data) {
      var element;
      element = $(employeeBlock);
      element.css({
        display: "flex"
      });
      return this._appendData(element, data);
    };

    PopUpWindowManager.prototype._showChief = function(employeeId) {
      var request, thisContext;
      thisContext = this;
      request = $.ajax({
        url: "/employee/" + employeeId + "/",
        type: "GET"
      });
      request.done(function(data, textStatus, jqXHR) {
        var element;
        if (jqXHR.status === 200) {
          element = $(chiefBlock);
          element.css({
            display: "flex"
          });
          return thisContext._appendData(element, data);
        }
      });
      return request.fail(function(jqXHR, textStatus, errorThrown) {
        return thisContext.showError("Не вдалося завантажити начальника робітника.");
      });
    };

    PopUpWindowManager.prototype._showEmployeesTree = function(employeeId) {
      var request, thisContext;
      thisContext = this;
      request = $.ajax({
        url: "/employee/" + employeeId + "/get_tree/",
        type: "GET"
      });
      return request.done(function(data, textStatus, jqXHR) {
        var containerTree, element, firstCall, getEmpTree, preDomTreeHtml;
        if (jqXHR.status === 200 && data.employee) {
          containerTree = $(employeesTreeBlock + " #tree-detail-container");
          preDomTreeHtml = "";
          firstCall = true;
          getEmpTree = function(employeeData) {
            var pCS, ulAppend;
            if (employeeData.self) {
              if (employeeData.self.subordinate_count >= 1) {
                if (firstCall) {
                  pCS = "<li><a>" + employeeData.self.subordinate_count + "</a></li>";
                } else {
                  if (employeeData.self.subordinate_count > 1) {
                    pCS = "<li><a>Та ще " + (employeeData.self.subordinate_count - 1) + "</a></li>";
                  } else {
                    pCS = "";
                  }
                }
              } else {
                pCS = "";
              }
              firstCall = false;
              ulAppend = preDomTreeHtml === "" && pCS === "" ? "" : "<ul>\n    " + preDomTreeHtml + "\n    " + pCS + "\n</ul>";
              preDomTreeHtml = "<li>\n    <a>" + employeeData.self.name + "</a>\n    " + ulAppend + "\n</li>";
            }
            if (employeeData.employee) {
              return getEmpTree(employeeData.employee);
            }
          };
          getEmpTree(data);
          containerTree.html("<ul>" + preDomTreeHtml + "</ul>");
          element = $(employeesTreeBlock);
          return element.css({
            display: "flex"
          });
        }
      });
    };

    PopUpWindowManager.prototype._appendData = function(element, data) {
      element.find("h4").text(data.name);
      element.find("h6").text(data.work_position);
      element.find("p").text(data.date_join);
      return element.find("h3").text(data.wage);
    };

    return PopUpWindowManager;

  })();

  $(document).ready(function() {
    var appendSpinner, delay, functionSearchBy, functionSortedBy, managerEmployees, managerPopUp, normalizeSendData, removeSpinner, replaceSpaces, sendSearchBy;
    managerPopUp = new PopUpWindowManager;
    managerEmployees = new AJAXEmployeesManager(40, 10, managerPopUp);
    managerEmployees.initEmployees();
    delay = function(callback, ms) {
      var timer;
      if (ms == null) {
        ms = 800;
      }
      timer = 0;
      return function() {
        var args, callbackRet, context;
        context = this;
        args = arguments;
        clearTimeout(timer);
        callbackRet = function() {
          return callback.apply(context, args);
        };
        return timer = setTimeout(callbackRet, ms || 0);
      };
    };
    appendSpinner = function(inputId) {
      $(inputId).each(function() {
        return $(this).attr("class", ($(this).attr('class')) + " width-input-append-spinner");
      });
      return $('<i class="fas fa-cog fa-spin"></i>').insertAfter(inputId);
    };
    removeSpinner = function(inputId) {
      if ($(inputId).next().is("i.fa-spin")) {
        return $(inputId).removeClass("width-input-append-spinner").next().remove();
      }
    };
    replaceSpaces = function(element) {
      var i, j, len, ref, resultString;
      resultString = '';
      ref = element.split(' ');
      for (j = 0, len = ref.length; j < len; j++) {
        i = ref[j];
        if (i !== '') {
          resultString += i + ' ';
        }
      }
      return resultString.slice(0, -1);
    };
    normalizeSendData = function(data) {
      var index, j, len, resultData, searchStrElem;
      if (indexOf.call(data, "|") >= 0) {
        resultData = data.split("|");
        for (index = j = 0, len = resultData.length; j < len; index = ++j) {
          searchStrElem = resultData[index];
          resultData[index] = replaceSpaces(searchStrElem);
        }
        return resultData;
      } else {
        return [replaceSpaces(data)];
      }
    };
    sendSearchBy = function() {
      var byNameData, byWageData, byWorkPositionData, limit, requestData, requestSearchFieldsData, sorted, url;
      byNameData = normalizeSendData($('#search-by-name-field').val());
      byWorkPositionData = normalizeSendData($('#search-by-work-position-field').val());
      byWageData = normalizeSendData($('#search-by-wage-field').val());
      requestSearchFieldsData = '';
      if (byNameData.length > 0 && byNameData[0] !== '') {
        requestSearchFieldsData += 'name__icontains=' + byNameData.join() + '|';
      }
      if (byWorkPositionData.length > 0 && byWorkPositionData[0] !== '') {
        requestSearchFieldsData += 'work_position__icontains=' + byWorkPositionData.join() + '|';
      }
      if (byWageData.length > 0 && byWageData[0] !== '') {
        requestSearchFieldsData += 'wage=' + byWageData.join() + '|';
      }
      if (requestSearchFieldsData.length === 0) {
        managerEmployees.showAllEmployeesInContainer();
        return false;
      }
      requestSearchFieldsData.slice(0, -1);
      requestData = encodeURIComponent(requestSearchFieldsData);
      limit = 20;
      sorted = encodeURIComponent($('#select-sorted-by').val());
      url = "/employee/search/?limit=" + limit + "&data=" + requestData + "&sorted=" + sorted;
      managerEmployees.clearContainer();
      managerEmployees.showFirstHierarchy(20, url, true);
      return true;
    };
    functionSearchBy = function(e) {
      var data, functionTimeout;
      data = e.currentTarget.value;
      appendSpinner(e.currentTarget);
      sendSearchBy();
      functionTimeout = function() {
        return removeSpinner(e.currentTarget);
      };
      return setTimeout(functionTimeout, 1000);
    };
    functionSortedBy = function(e) {
      if (sendSearchBy()) {
        return;
      }
      managerEmployees.clearContainer();
      managerEmployees.removeEmployees();
      return managerEmployees.initEmployees();
    };
    $('#search-by-name-field').keyup(delay(functionSearchBy));
    $('#search-by-work-position-field').keyup(delay(functionSearchBy));
    $('#search-by-wage-field').keyup(delay(functionSearchBy));
    return $('#select-sorted-by').change(functionSortedBy);
  });

}).call(this);
