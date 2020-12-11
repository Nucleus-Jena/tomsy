RailsAdmin.config do |config|
  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  config.authorize_with :cancancan
  config.current_user_method(&:current_user)
  config.parent_controller = "ApplicationController"

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  config.audit_with :paper_trail, "User", "PaperTrail::Version" # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  # hide all event subclasses in rails admin
  Rails.root.join("app", "models", "events").entries.each do |filepath|
    config.excluded_models << "Events::#{filepath.basename(".rb").to_s.camelize}"
  end

  config.actions do
    dashboard # mandatory
    index # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    history_index
    history_show
  end

  config.model "User" do
    configure :camunda_identifier do
      read_only true
    end

    configure :user_groups do
      visible false
    end

    create do
      configure :groups do
        visible false
      end
    end

    edit do
    end
  end

  config.model "Group" do
    configure :camunda_identifier do
      read_only true
    end

    configure :user_groups do
      visible false
    end

    create do
      configure :users do
        visible false
      end
    end
  end

  config.model "Event" do
    configure :data, :text
  end

  config.model "DossierDefinition" do
    configure :identifier do
      read_only do
        !bindings[:object].new_record?
      end
    end

    create do
      configure :fields do
        visible false
      end
    end
  end

  config.model "DossierDefinitionField" do
    configure :definition do
      read_only do
        !bindings[:object].new_record?
      end
    end

    configure :identifier do
      read_only do
        !bindings[:object].new_record?
      end
    end
  end
end
