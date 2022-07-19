import Vue from "vue/dist/vue.min.js";

import axios from "axios";

const MINUTES_BEFORE_EXPIRATION = 10;
const INTERVAL_TIME = 10000;

// Get the token expiration from the access token
var tokenExpiration;

document.addEventListener("DOMContentLoaded", () => {
  axios.defaults.headers.common["X-CSRF-Token"] = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute("content");
  const app = new Vue({
    el: "#reports",
    data: {
      search: "",
      workspacesLoading: false,
      reportLoading: false,
      workspaces: [],
      reportLoaded: false,
      noPermissions: false,
      notAuthorized: false,
      adminPages: true,
      showProfileDropDown: false,
      showFilterWorkspaces: false,
      showNoReportsMessage: false,
      last_viewed_workspace: "",
      last_viewed_report: "",
      showContactUs: "",
      showContactUsConfirmation: "",
      contactusmodels:{},
      navAnnouncement: "",
      selectedWorkspace: {},
      showMaintenanceWorkspace: false
    },
    created() {
      this.workspacesLoading = true;
      axios.get("/users/last_viewed").then(response=>{
        this.last_viewed_report = response.data.last_viewed_report;
        this.last_viewed_workspace = response.data.last_viewed_workspace;
      })
      axios.get("/workspaces").then(response => {
        this.workspaces = _.map(response.data, function (item) {
          item["reports"] = [];
          item["selected"] = false;
          return item;
        }).sort((a, b) => (a.name > b.name ? 1 : -1));
        if (this.workspaces.length == 0) {
          this.noPermissions = true;
        }
        this.workspacesLoading = false;

        if(this.workspaces.length > 0) {
          this.loadWorkspaceOnLoad()
        }
      });
    },

    computed: {
      filteredWorkspaces() {
        return this.workspaces.filter(workspace => {
          return (
            workspace.name.toLowerCase().indexOf(this.search.toLowerCase()) > -1
          );
        });
      }
    },

    methods: {
      checkTokenAndUpdate: function(reportId, groupId, datasetId) {
        // Get the current time
        const currentTime = Date.now();
        const expiration = Date.parse(tokenExpiration);

        // Time until token expiration in milliseconds
        const timeUntilExpiration = expiration - currentTime;
        const timeToUpdate = MINUTES_BEFORE_EXPIRATION * 60 * 1000;
       
        // Update the token if it is about to expired
        if (timeUntilExpiration <= timeToUpdate)
        {
            this.updateToken(reportId, groupId, datasetId);
        }
      },
      updateToken: function(reportId, groupId, datasetId) {
        let params = {"report_id": reportId, "workspace_id": groupId, "dataset_id": datasetId}

        axios
          .post("/reports/refresh_token", params).then(response => {
          tokenExpiration = response.data.expiration;

          let embedContainer = document.getElementById("reportContainer");
          let report = powerbi.get(embedContainer);
          report.setAccessToken(response.data.token);
        }) 
      },
      loadWorkspaceOnLoad: function(attempts=0) {
        if (this.last_viewed_workspace == "" || this.last_viewed_workspace == null) {
          if (document.getElementsByClassName("workspace-name").length != 0) {
            document.getElementsByClassName("workspace-name")[0].click();
          } else {
            setTimeout(function(){
              if(attempts < 10){
                this.loadWorkspaceOnLoad(attempts + 1)
              }
            }.bind(this), 500);
          }
        } else {
          var last_viewed_workspace = this.last_viewed_workspace;
          var workspace = _.filter(this.workspaces, function (workspace) {
            return workspace.id == last_viewed_workspace
          })[0]
          this.loadReportsForWorkspace(workspace)
        }
      },
      focusWorkspaceFilter: function () {
        setTimeout(
          function () {
            this.$refs.filterWorkspaces.focus();
          }.bind(this),
          200
        );
      },
      loadReportsForWorkspace(workspace) {
        if(workspace.maintain == true){
          console.log(workspace.name);
          this.showMaintenanceWorkspace = true;
        }
        else{
          this.showMaintenanceWorkspace = false;
        this.showNoReportsMessage = false;
        if (workspace.selected) {
          workspace.selected = false;
        } else {
          workspace.selected = true;
          axios
            .get("/workspaces/" + workspace.id + "/reports")
            .then(response => {
              workspace.reports = _.map(response.data.value, function (report) {
                report["isActive"] = false;
                return report;
              }).sort((a, b) => (a.name > b.name ? 1 : -1));

              if (workspace.reports.length > 0) {
                setTimeout(function () {

                  if (this.last_viewed_workspace == "" || this.last_viewed_workspace == null) {
                    if (document.getElementsByClassName("workspace-reports")) {
                      document
                        .getElementsByClassName("workspace-reports")[0]
                        .click();
                    }
                  } else {
                    var last_viewed_report = this.last_viewed_report;
                    var report = _.filter(workspace.reports, function (report) {
                      return report.name == last_viewed_report.replace("&amp;", "&");
                    })[0]

                    if(report){
                      this.showReport(report, workspace)
                    }

                    
                  }
                }.bind(this), 500);
              } else {
                workspace.no_reports = true
              } 
            });
        }
        }
      },
      fullScreen() {
        var embedContainer = document.getElementById("reportContainer");
        let report = powerbi.get(embedContainer);
        report.fullscreen();
      },
      resetPowerBi(){
        let reportContainer = document.getElementById("reportContainer");
        powerbi.reset(reportContainer);
        _.each(this.workspaces, function (workspace) {
          _.each(workspace.reports, function (report) {
            report.isActive = false;
          });
        });
        this.showNoReportsMessage = true
      },
      showReport(report, workspace) {
        //these are for the refresh token 
        this.reportId = report.id;
        this.datasetId = report.datasetId;

        this.showNoReportsMessage = false;
        this.notAuthorized = false;
        this.reportLoading = true;
        this.reportLoaded = false;
        _.each(this.workspaces, function (workspace) {
          _.each(workspace.reports, function (report) {
            report.isActive = false;
          });
        });
        report.isActive = true;
        let thisReport = report;
        let reportContainer = document.getElementById("reportContainer");
        powerbi.reset(reportContainer);
        this.getPowerBiAccessToken(report, workspace).then(response => {
          if (response.data.error) {
            this.notAuthorized = true;
            this.reportLoading = false;
          } else {
            var data = response.data;
            tokenExpiration = data.expiration;
            var config = {
              type: "report",
              accessToken: data.token,
              embedUrl: thisReport.embedUrl,
              tokenType: window["powerbi-client"].models.TokenType.Embed,
              id: thisReport.id,
              settings: {
                filterPaneEnabled: true,
                navContentPanelEnabled: true
              }
            };
            powerbi.preload(config);
            this.reportLoading = false;
            var report = powerbi.embed(reportContainer, config);
            report.on(
              "loaded",
              function () {
                var powerBIFrame = document
                  .getElementsByClassName("powerbi-container")[0]
                  .getElementsByTagName("iframe")[0];
                powerBIFrame.classList.add("powerbi-container-border");
                this.reportLoaded = true;

                // Set an interval to check the access token expiration, and update if needed
                setInterval(() => this.checkTokenAndUpdate(this.reportId, workspace.pbi_workspace_id, this.datasetId), INTERVAL_TIME);

              }.bind(this)
            );
          }
        });
      },
      getPowerBiAccessToken(report, workspace) {
        var params = {
          report_id: report.id,
          idempotence_key: workspace.id,
          workspace_id: workspace.pbi_workspace_id,
          dataset_id: report.datasetId,
          report_name: report.name,
          workspace_name: workspace.name
        };

        return axios.post("/reports/token", params);
      },
      contactUs: function() {
        axios
          .post(`/contactus/`, {
            contactusmodels: this.contactusmodels
          })
          .then(response => {
            if (response.data.status == "created") {
              this.contactusmodels.push(response.data);
              this.flash("ContactUs created", "success", { timeout: 3000 });
            }
          });
      },
      setWorkspace: function(workspace) {
        this.workspace = workspace;
        this.selectedWorkspace = workspace;
      }
    }
  });
});
