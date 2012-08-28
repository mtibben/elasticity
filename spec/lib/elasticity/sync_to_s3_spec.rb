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
      let(:both_keys_missing) { Elasticity::SyncToS3.new('_') }

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

          both_keys_missing.access_key.should == 'ENV_ACCESS'
          both_keys_missing.secret_key.should == 'ENV_SECRET'
        end
      end

      context 'when environment variables are not present' do

        context 'when access is not set' do
          let(:access_key) { nil }
          let(:secret_key) { '_' }
          it 'should raise an error' do
            expect {
              both_keys_nil # Trigger instantiation
            }.to raise_error(Elasticity::MissingKeyError, 'Please provide an access key or set AWS_ACCESS_KEY_ID.')
          end
        end

        context 'when secret is not set' do
          let(:access_key) { '_' }
          let(:secret_key) { nil }
          it 'should raise an error' do
            expect {
              both_keys_nil # Trigger instantiation
            }.to raise_error(Elasticity::MissingKeyError, 'Please provide a secret key or set AWS_SECRET_ACCESS_KEY.')
          end
        end

      end

    end

  end

  describe '#sync' do

    include FakeFS::SpecHelpers
    Fog.mock!

    let(:sync_to_s3) { Elasticity::SyncToS3.new(bucket_name, '_', '_') }
    let(:s3) { Fog::Storage.new({:provider => 'AWS', :aws_access_key_id => '', :aws_secret_access_key => ''}) }

    before do
      sync_to_s3.stub(:s3).and_return(s3)
    end

    context 'when the bucket exists' do

      let(:bucket_name) { 'GOOD_BUCKET' }
      before do
        s3.directories.create(:key => bucket_name)
      end

      context 'when the local directory does not exist' do
        it 'should raise an error' do
          expect {
            sync_to_s3.sync('BAD_DIR', '_')
          }.to raise_error(Elasticity::NoDirectoryError, "Directory 'BAD_DIR' does not exist or is not a directory")
        end
      end

      context 'when the local directory is not a directory' do
        before do
          FileUtils.touch('NOT_A_DIR')
        end
        it 'should raise an error' do
          expect {
            sync_to_s3.sync('NOT_A_DIR', '_')
          }.to raise_error(Elasticity::NoDirectoryError, "Directory 'NOT_A_DIR' does not exist or is not a directory")
        end
      end

    end

    context 'when the bucket does not exist' do
      let(:bucket_name) { 'BAD_BUCKET' }
      it 'should raise an error' do
        expect {
          sync_to_s3.sync('_', '_')
        }.to raise_error(Elasticity::NoBucketError, "Bucket 'BAD_BUCKET' does not exist")
      end
    end

  end

end