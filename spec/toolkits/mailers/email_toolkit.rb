module Toolkits
  module Mailers
    module EmailToolkit

      module Definitions
        def define_email_context
          let(:email) { ActionMailer::Base.deliveries.last }
          let(:sender) { ExportsMailer::SENDER_EMAIL }
          let(:admin_email) { ExportsMailer::ADMIN_EMAIL }
          let(:text_part) { email.body.parts.detect {|part| part.content_type.match "text/plain" }}
          let(:html_part) { email.body.parts.detect {|part| part.content_type.match "text/html" }}
        end
      end

      module SharedExamples
        RSpec.shared_examples "an email text part" do
          it "doesn't include a template" do
            should_not include "Regents of The University of Michigan"
          end
        end

        RSpec.shared_examples "an email html part" do
          it "should use include a template" do
            should include "Regents of The University of Michigan"
          end

          it "declares a doctype" do
            should include "DOCTYPE"
          end
        end

        RSpec.shared_examples "a gradecraft email to a professor" do
          it "is sent from gradecraft's default mailer email" do
            expect(email.from).to eq [sender]
          end

          it "is sent to the professor's email" do
            expect(email.to).to eq [professor.email]
          end
        end

        RSpec.shared_examples "a gradecraft email to a student" do
          it "is sent from gradecraft's default mailer email" do
            expect(email.from).to eq [sender]
          end

          it "is sent to the professor's email" do
            expect(email.to).to eq [professor.email]
          end
        end
      end

    end
  end
end
