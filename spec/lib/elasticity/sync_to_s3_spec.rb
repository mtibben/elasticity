describe Elasticity::SyncToS3 do

  describe '#initialize' do

    describe 'basic assignment' do

      it 'should set the proper values' do
        sync = Elasticity::SyncToS3.new('bucket', 'access', 'secret')
        sync.access_key.should == 'access'
        sync.secret_key.should == 'secret'
        sync.bucket_name.should == 'bucket'
      end

    end

    context 'when access and secret keys are nil' do

      let(:both_keys_nil) { Elasticity::SyncToS3.new('_', nil, nil) }

      before do
        ENV.stub(:[]).with('AWS_ACCESS_KEY_ID').and_return(access_key)
        ENV.stub(:[]).with('AWS_SECRET_ACCESS_KEY').and_return(secret_key)
      end

      context 'when environment variables are present' do
        let(:access_key) { 'ENV_ACCESS' }
        let(:secret_key) { 'ENV_SECRET' }
        it 'should assign them to the keys' do
          both_keys_nil.access_key.should == 'ENV_ACCESS'
          both_keys_nil.secret_key.should == 'ENV_SECRET'
        end
      end

      context 'when environment variables are not present' do

        context 'when access is not set' do
          let(:access_key) { nil }
          let(:secret_key) { '_' }
          it 'should raise an error' do
            expect {
              both_keys_nil.access_key
            }.to raise_error(Elasticity::MissingKeyError, 'Please provide an access key or set AWS_ACCESS_KEY_ID.')
          end
        end

        context 'when secret is not set' do
          let(:access_key) { '_' }
          let(:secret_key) { nil }
          it 'should raise an error' do
            expect {
              both_keys_nil.secret_key
            }.to raise_error(Elasticity::MissingKeyError, 'Please provide a secret key or set AWS_SECRET_ACCESS_KEY.')
          end
        end

      end

    end

  end

end