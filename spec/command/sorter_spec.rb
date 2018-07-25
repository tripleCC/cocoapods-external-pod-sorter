require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Sorter do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ sorter }).should.be.instance_of Command::Sorter
      end
    end
  end
end

