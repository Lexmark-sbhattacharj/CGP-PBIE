import Vue from "vue/dist/vue.min.js";

import VueFlashMessage from "vue-flash-message";

Vue.use(VueFlashMessage);
import axios from "axios";

document.addEventListener("DOMContentLoaded", () => {
  axios.defaults.headers.common["X-CSRF-Token"] = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute("content");
  const app = new Vue({
    el: "#reports",
    data: {
      search: "",
      workspacesLoading: false,
      workspaces: [],
      selectedWorkspace: {},
      noPermissions: false,
      notAuthorized: false,
      addUser: false,
      editUser: false,
      deleteUser: false,
      addWorkspace: false,
      editWorkspace: false,
      workspace: {},
      user: {},
      showActivity: false,
      deleteWorkspace: false,
      userActivity: { user: {} },
      showFilterWorkspaces: false,
      showWorkspaceMenu: false,
      showProfileDropDown: false,
      errors: [],
      showContactUs: "",
      showContactUsConfirmation: "",
      contactusmodels:{},
      newAnnouncement: "",
      newAnnouncementConfirmation: "",
      announcements:{},
      showAnnouncement: "",
      indexAnnouncement: ""
    },
    created() {
      this.workspacesLoading = true;
      axios.get("/workspaces").then(response => {
        this.workspaces = _.map(response.data, function(item) {
          item["selected"] = false;
          return item;
        }).sort((a, b) => (a.name > b.name ? 1 : -1));
        if (this.workspaces.length == 0) {
          this.noPermissions = true;
        } else {
          setTimeout(function() {
            if (document.getElementsByClassName("workspace-name")) {
              document.getElementsByClassName("workspace-name")[0].click();
            }
          }, 200);
        }
        this.workspacesLoading = false;
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
      focusWorkspaceFilter: function() {
        setTimeout(
          function() {
            this.$refs.filterWorkspaces.focus();
          }.bind(this),
          200
        );
      },
      loadActivity: function(user) {
        this.showActivity = true;
        axios.get(`/users/${user.id}`).then(response => {
          this.userActivity = response.data;
        });
      },
      setUser: function(user) {
        this.user = user;
      },
      removeUser: function() {
        axios
          .delete(
            `/workspaces/${this.selectedWorkspace.id}/users/${this.user.id}`
          )
          .then(response => {
            this.selectedWorkspace.users = _.remove(
              this.selectedWorkspace.users,
              function(user) {
                return this.user.id != user.id;
              }.bind(this)
            );
            this.flash("User removed", "success", { timeout: 3000 });
            this.deleteUser = false;
          });
      },
      setWorkspace: function(workspace) {
        this.workspace = workspace;
        this.selectedWorkspace = workspace;
      },

      backToReports: function() {
        location.href = "/";
      },

      updateUser: function() {
        axios
          .patch(`/users/${this.user.id}`, {
            user: this.user
          })
          .then(response => {
            this.editUser = false;
            this.flash("User updated", "success", { timeout: 3000 });
          });
      },

      createUser: function() {
        axios
          .post(`/workspaces/${this.selectedWorkspace.id}/users/`, {
            user: this.user
          })
          .then(response => {
            this.workspace = this.selectedWorkspace;
            if (response.data.status == "created") {
              this.workspace.users.push(response.data.user);
              this.flash("User created", "success", { timeout: 3000 });
            }

            this.addUser = false;
          });
      },
      createWorkspace: function() {
        axios
          .post("/workspaces/", { workspace: this.workspace })
          .then(response => {
            if (response.data.errors) {
              this.errors = response.data.errors;
            } else {
              this.workspaces.push(response.data);
              this.workspace = response.data;
              this.selectedWorkspace = this.workspace;
              this.addWorkspace = false;
            }
        
          });
      },
      saveWorkspace: function() {
        axios
          .patch(`/workspaces/${this.workspace.id}`, {
            workspace: this.workspace
          })
          .then(reponse => {
            this.editWorkspace = false;
          });
      },
      loadEditWorkspace: function(workspace) {
        workspace.selected = true;
        this.editWorkspace = true;
        this.setWorkspace(workspace);
      },
      removeWorkspace: function() {
        this.selectedWorkspace = {};
        axios.delete(`/workspaces/${this.workspace.id}`).then(response => {
          this.workspaces = _.remove(
            this.workspaces,
            function(workspace) {
              return this.workspace.id != workspace.id;
            }.bind(this)
          );
          this.workspace = {};
          this.deleteWorkspace = false;
          this.selectedWorkspace = this.workspaces[0];
          if (document.getElementsByClassName("workspace-name")) {
            document.getElementsByClassName("workspace-name")[0].click();
          }
        });
      },
      loadUsers(workspace) {
        if (workspace.selected) {
          workspace.selected = false;
        } else {
          workspace.selected = true;
          axios.get("/workspaces/" + workspace.id).then(response => {
            workspace.users = _.uniqWith(response.data.users.sort((a, b) =>
              a.name > b.name ? 1 : -1
            ), _.isEqual);
            this.selectedWorkspace = workspace;
          });
        }
      },
      announcement: function() {
        axios
          .post(`/announcements/`, {
            announcements: this.announcements
          })
          .then(response => {
            if (response.data.status == "created") {
              this.announcements.push(response.data);
              this.flash("Announcement created", "success", { timeout: 3000 });
            }
          });
      },
      backToAnnouncement: function() {
        location.href = "/announcements";
      },
    }
  });
});
