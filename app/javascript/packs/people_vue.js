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
      usersLoading: false,
      users: [],
      selectedUser: {},
      noPermissions: false,
      notAuthorized: false,
      addUser: false,
      editUser: false,
      deleteUser: false,
      user: {},
      showActivity: false,
      deleteUser: false,
      userActivity: { user: {} },
      showFilterUsers: false,
      showUserMenu: false,
      showProfileDropDown: false,
      errors: [],
      usage_metrics: [],
      workspaces: [],
      removeWorkspaceAccess: false,
      selectedWorkspace: {},
      confirmB2CStatus: false,
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
      this.usersLoading = true;
      axios.get("/users").then(response => {
        this.users = _.map(response.data, function(item) {
          item["selected"] = false;
          return item;
        }).sort((a, b) => (a.email > b.email ? 1 : -1));
        if (this.users.length == 0) {
          this.noPermissions = true;
        } else {
          setTimeout(function() {
            if (document.getElementsByClassName("user-name")) {
              document.getElementsByClassName("user-name")[0].click();
            }
          }, 200);
        }
        this.usersLoading = false;
      });
    },

    computed: {
      filteredUsers() {
        return this.users.filter(user => {
          return (
            user.email.toLowerCase().indexOf(this.search.toLowerCase()) > -1
          );
        });
      }
    },

    methods: {
      focusUserFilter: function() {
        setTimeout(
          function() {
            this.$refs.filterUsers.focus();
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

      removeUser: function() {
       axios.delete(`/users/${this.user.id}`).then(response => {
        this.deleteUser = false;
        this.users = _.remove(
            this.users,
            function(user) {
              return this.user.id != user.id;
            }.bind(this)
          )
        

        this.usage_metrics = [];
        this.workspaces = [];
        this.selectedUser = {};

        setTimeout(function() {
          if (document.getElementsByClassName("user-name")) {
            document.getElementsByClassName("user-name")[0].click();
          }
        }, 200);

        this.flash("User Deleted", "success", { timeout: 3000 });
       })
       
      },

      removeWorkspaceAccessForUser: function(){
        axios
        .delete(
          `/workspaces/${this.selectedWorkspace.id}/users/${this.user.id}`
        )
        .then(response => {
          this.workspaces = _.remove(
            this.workspaces,
            function(workspace) {
              return this.selectedWorkspace.id != workspace.id;
            }.bind(this)
          );
          this.flash("Workspace access removed", "success", { timeout: 3000 });
          this.removeWorkspaceAccess = false;
        });
      },

      setUser: function(user) {
        this.user = user;
        this.selectedUser = user;
      },

      backToReports: function() {
        location.href = "/";
      },

      confirmB2CStatusAction: function() {
        axios
          .post("/admin/confirm_b2c_status", {
            email: this.user.email
          })
          .then(response => {
            if(response.data.status == "exists"){
              this.flash("User is already registered with B2C and can reset their password.", "success", { timeout: 6000});
              this.confirmB2CStatus = false;
              this.showUserMenu = false;
            } else {
              this.flash(`${this.user.email} was registered in B2C. The response from B2C was ${JSON.stringify(response.data.message)}.`, "success", { timeout: 6000});
              this.confirmB2CStatus = false;
              this.showUserMenu = false;
            }
          });
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

      loadUser(user) {
        user.selected = true;
        axios.get("/users/" + user.id).then(response => {
          this.user = response.data.user;
          this.usage_metrics = response.data.usage_metrics;
          this.workspaces = response.data.workspaces;
          this.selectedUser = user;
        });
  
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
      announcement: function() {
        axios
          .post(`/announcements/`, {
            announcements: this.announcements
          })
          .then(response => {
            if (response.data.status == "created") {
              this.announcement.push(response.data);
              this.flash("Announcement created", "success", { timeout: 3000 });
            }
          });
      }
    }
  });
});
