module Services
  class AppDestroyer
    def self.call(app)
      new(app).call
    end

    def initialize(app)
      @app = app
    end

    def call
      confirm

      AppsRepository.destroy(app: @app)

      puts "App #{@app.id} is scheduled for destruction"
    end

    private

    def confirm
      Confirmator.confirm(
        question: "Are you sure you want to destroy the app #{@app.id} " \
                  "and its enviroments on profile #{Services::Kube.current_profile}? " \
                  'This action is irreversible.'
      )
    end
  end
end
