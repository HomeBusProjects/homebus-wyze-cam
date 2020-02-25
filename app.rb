require 'homebus'
require 'homebus_app'
require 'mqtt'
require 'json'
require 'dotenv'

require 'net/http'
require 'base64'
require 'timeout'

class CameraHomeBusApp < HomeBusApp
  def initialize(options)
    @options = options

    super
  end


  def setup!
    Dotenv.load('.env')
    @url = ENV['CAMERA_URL']
  end

  def get_image
    begin
      response = Timeout::timeout(30) do
        uri = URI(@url)
        #        response = Net::HTTP.get_response(uri)
        req = Net::HTTP::Get.new(uri.path)
        req.basic_auth ENV['CAMERA_USERNAME'], ENV['CAMERA_PASSWORD']
        response = Net::HTTP.start(uri.host,
                                   uri.port, 
                                   use_ssl: uri.scheme == 'https',
                                   verify_mode: OpenSSL::SSL::VERIFY_NONE) do |https|
          https.request(req)
        end
      end

      if response.code == "200"
        File.open('photo.jpg', 'w') do |f| f.write(response.body) end

        return {
          mime_type: 'image/jpeg',
          data: Base64.encode64(response.body)
        }
      else
        nil
      end
    rescue
      puts "timeout"
      nil
    end
  end

  def work!
    image = get_image

    if image
      obj = {
        id: @uuid,
        timestamp: Time.now.to_i,
        image: image
      }

      @mqtt.publish '/homebus/device/' + @uuid,
                    JSON.generate(obj),
                    true

    else
      puts "no image"
    end

    sleep 60
  end

  def manufacturer
    'HomeBus'
  end

  def model
    '1'
  end

  def friendly_name
    'Wyze Camera Still Frame'
  end

  def friendly_location
    'PDX Hackerspace Hydroponics Camera'
  end

  def serial_number
    ENV['CAMERA_LOCATION']
  end

  def pin
    ''
  end

  def devices
    [
      { friendly_name: 'Camera stills',
        friendly_location: 'PDX Hackerspace',
        update_frequency: 60,
        index: 0,
        accuracy: 0,
        precision: 0,
        wo_topics: [ '/cameras' ],
        ro_topics: [],
        rw_topics: []
      }
    ]
  end
end
