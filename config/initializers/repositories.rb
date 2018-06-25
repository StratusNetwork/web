Repository.define do
    repositories provider: :github, namespace: 'StratusNetwork' do
        repository :data do
            klass           Repository::Data
            repo            'Data'
            branch          'master'
            services        [:data]
        end

        visible? true do
            repository :projectares do
                title           "ProjectAres"
                description     "Our custom Bukkit plugins (such as PGM) that control matches and add network features to Minecraft"
                repo            "projectares"
                open?           true
            end

            repository :sportbukkit do
                title           "SportBukkit"
                description     "Our open source fork of Bukkit that is finely tuned for competitive Minecraft"
                repo            "SportBukkit"
                open?           true
            end

            repository :web do
                title           "Website"
                description     "Our main website and backend repository"
                repo            "web"
                open?           true
            end

            repository :static do
                title           "Data"
                description     "Our static configuration data files for the servers"
                repo            "data"
                open?           true
            end

            repository :docs do
                title           "XML Documentation"
                description     "Our XML documentation website for defining map specific features"
                repo            "xml"
                branch          "gh-pages"
                open?           true
            end
        end
    end
end
