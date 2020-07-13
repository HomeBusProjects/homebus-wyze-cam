require 'homebus'
require 'homebus_app'
require 'mqtt'
require 'json'
require 'dotenv'

require 'net/http'
require 'base64'
require 'timeout'

class CameraHomeBusApp < HomeBusApp
  DDC = 'org.homebus.experimental.image'

  def initialize(options)
    @options = options

    super
  end


  def setup!
    Dotenv.load('.env')
    @url = ENV['CAMERA_URL']
  end

  def _get_image
    begin
      response = Timeout::timeout(30) do
        uri = URI(@url)
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
        return nil if response.body == ''

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
    image = _get_image

    if image
      publish! DDC, image
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
        wo_topics: [ DDC ],
        ro_topics: [],
        rw_topics: []
      }
    ]
  end
end
