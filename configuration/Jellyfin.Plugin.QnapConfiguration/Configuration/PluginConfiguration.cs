using MediaBrowser.Model.Plugins;

namespace Jellyfin.Plugin.QnapConfiguration.Configuration
{
    /// <summary>
    /// The configuration options.
    /// </summary>
    public enum SomeOptions
    {
        /// <summary>
        /// Second option.
        /// </summary>
        defaultValue,

        /// <summary>
        /// Option one.
        /// </summary>
        iHD,

        /// <summary>
        /// Second option.
        /// </summary>
        i965,
    }

    /// <summary>
    /// Plugin configuration.
    /// </summary>
    public class PluginConfiguration : BasePluginConfiguration
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="PluginConfiguration"/> class.
        /// </summary>
        public PluginConfiguration()
        {
            // set default options here
            VaapiDriver = SomeOptions.defaultValue;
        }

        /// <summary>
        /// Gets or sets an enum option.
        /// </summary>
        public SomeOptions VaapiDriver { get; set; }
    }
}
