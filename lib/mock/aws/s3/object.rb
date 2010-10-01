require 'ftools'
require 'ostruct'

module AWS
  module S3

    class S3Object
      class << self

        def value(key, bucket = nil, options = {}, &block)
          data = File.open(path!(bucket, key, options)) {|f| f.read}
          Value.new OpenStruct.new(:body=>data)
        end

        # def stream(key, bucket = nil, options = {}, &block)
        #   data = File.open(path!(bucket, key, options)) {|f| f.read}
        #   Value.new Response.new(:body=>data)
        #   value(key, bucket, options) do |response|
        #     response.read_body(&block)
        #   end
        # end

        # # Returns the object whose key is <tt>name</tt> in the specified bucket. If the specified key does not
        # # exist, a NoSuchKey exception will be raised.
        # def find(key, bucket = nil)
        #   key    = key.remove_extended unless key.valid_utf8?
        #   bucket = Bucket.find(bucket_name(bucket), :marker => key.previous, :max_keys => 1)
        #   # If our heuristic failed, trigger a NoSuchKey exception
        #   if (object = bucket.objects.first) && object.key == key
        #     object
        #   else
        #     raise NoSuchKey.new("No such key `#{key}'", bucket)
        #   end
        # end


        # Makes a copy of the object with <tt>key</tt> to <tt>copy_key</tt>, preserving the ACL of the existing object if the <tt>:copy_acl</tt> option is true (default false).
        def copy(key, copy_key, bucket = nil, options = {})
          bucket          = bucket_name(bucket)
          source_key      = path!(bucket, key)
          target_key      = path!(bucket, copy_key)
          File.makedirs File.dirname(target_key)
          FileUtils.cp_r source_key, target_key
        end

        #
        # # Fetch information about the object with <tt>key</tt> from <tt>bucket</tt>. Information includes content type, content length,
        # # last modified time, and others.
        # #
        # # If the specified key does not exist, NoSuchKey is raised.
        # def about(key, bucket = nil, options = {})
        #   response = head(path!(bucket, key, options), options)
        #   raise NoSuchKey.new("No such key `#{key}'", bucket) if response.code == 404
        #   About.new(response.headers)
        # end
        #

        def exists?(key, bucket = nil)
          File.exists?(path!(bucket, key))
        end

        def delete(key, bucket = nil, options = {})
          File.unlink path!(bucket, key, options)
        end

        def store(key, data, bucket = nil, options = {})
          validate_key!(key)
          # Must build path before infering content type in case bucket is being used for options
          path = path!(bucket, key, options)
          infer_content_type!(key, options)

          File.makedirs File.dirname(path)
          File.open(path, 'wb') do |f|
            f.write data
          end
        end
        alias_method :create, :store
        alias_method :save,   :store

        TEMP_PATH = begin
          if defined?(::Rails)
            Rails.root.to_s
          else
            '.'
          end
        end

        def path!(bucket, name, options = {}) #:nodoc:
          # We're using the second argument for options
          if bucket.is_a?(Hash)
            options.replace(bucket)
            bucket = nil
          end
          TEMP_PATH.clone << File.join('/tmp', 'mock-aws-s3', bucket_name(bucket), name)
        end

      end
    end
  end
end
